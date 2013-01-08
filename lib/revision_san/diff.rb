require 'diff/lcs'

module RevisionSan
  # Return a RevisionSan::Diff object which compares this revision to the specified revision.
  #
  #   artist = Artist.create(:name => 'van Gogh')
  #   artist.update_attribute(:name => 'Vincent van Gogh')
  #
  #   revision_1 = artist.fetch_revision(1)
  #   diff = revision_1.compare_against_revision(2)
  #   diff.name # => '<ins>Vincent </ins>van Gogh'
  def compare_against_revision(revision)
    Diff.new(self, fetch_revision(revision))
  end
  
  class Diff
    attr_reader :from, :to
    
    def initialize(from, to)
      @from, @to = from, to
    end
    
    def diff_for_column(column, &block)
      SimpleHTMLFormatter.diff(
        self.class.split(@from.send(column), &block),
        self.class.split(@to.send(column), &block)
      )
    end
    
    def method_missing(method, *args, &block)
      if @from.respond_to?(method) || @from.class.column_names.include?(method.to_s)
        define_and_call_singleton_method(method, &block)
      else
        super
      end
    end
    
    def define_and_call_singleton_method(method, &block)
      instance_eval %{
        def #{method}(&block)
          diff_for_column('#{method}', &block)
        end
        
        #{method}(&block)
      }
    end
    
    def self.split(text, &block)
      text = text.to_s
      text = block.call(text) if block_given?
      text.lines.to_a
    end
    
    module SimpleHTMLFormatter
      def self.diff(from_lines, to_lines)
        LineDiffHTMLFormatter.new(from_lines, to_lines).output
      end
      
      class LineDiffHTMLFormatter
        def output
          @output.join.gsub(%r{</ins><ins>|</del><del>|<del></del>}, '')
        end
        
        def initialize(from, to)
          @output = []
          @went_deep = false
          ::Diff::LCS.traverse_sequences(from, to, self)
        end
        
        def discard_a(change)
          from_words, to_words = [change.old_element, change.new_element].map { |text| text.to_s.scan(/\w+|\W|\s/) }
          changes = ::Diff::LCS.diff(from_words, to_words).length
          if changes > 1 && changes > (from_words.length / 5)
            @output << "<del>#{change.old_element}</del>"
          else
            @output << WordDiffHTMLFormatter.new(from_words, to_words).output
            @went_deep = true
          end
        end
        
        def discard_b(change)
          if @went_deep
            @went_deep = false
          else
            @output << "<ins>#{change.new_element}</ins>"
          end
        end
        
        def match(match)
          @output << match.new_element
        end
      end
      
      class WordDiffHTMLFormatter < LineDiffHTMLFormatter
        def output
          @output.join
        end
        
        def discard_a(change)
          @output << "<del>#{change.old_element}</del>"
        end
      end
    end
  end
end