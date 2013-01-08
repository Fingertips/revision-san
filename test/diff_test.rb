require File.expand_path('../test_helper', __FILE__)

class DiffTestEntity
  def self.column_names
    ["text"]
  end
  
  attr_accessor :text
  
  def initialize(text)
    @text = text
  end
end

def long_text
  {
    :before => %{Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Fusce gravida. Ut orci orci, molestie et, scelerisque ut, faucibus pharetra, enim. Morbi vehicula consequat nunc. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Quisque ac orci. Proin adipiscing tempor erat. Phasellus gravida tincidunt sapien. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. In venenatis libero sit amet quam. Nam sapien diam, tempor placerat, feugiat quis, congue in, elit. Vivamus nec enim eget elit posuere tincidunt. Quisque scelerisque lobortis risus. Quisque cursus dolor sit amet arcu.

Suspendisse auctor. Quisque sodales dapibus pede. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Cras blandit tellus id libero. Morbi sed purus sed sapien ornare facilisis. Vestibulum rutrum egestas mauris. Vestibulum luctus velit vitae ante. In dictum, metus sed lacinia sagittis, leo diam elementum tortor, rutrum elementum justo tellus eget risus. Curabitur faucibus mauris eget nisi. Nam mattis nunc eget turpis. In porta. Aliquam risus ante, sodales quis, consequat vitae, fermentum ut, nisi. Etiam congue ipsum id ante aliquet dictum.},
    
    :after => %{Landscape architecture involves the investigation and designed response to the landscape. The scope of the profession includes architectural design, site planning, environmental restoration, town or urban planning, urban design, parks and recreation planning. A practitioner in the field of landscape architecture is called a landscape architect.

Suspendisse auctor. Quisque sodales dapibus pede. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Cras blandit tellus id libero. Morbi sed purus sed sapien ornare facilisis. Vestibulum rutrum egestas mauris. Vestibulum luctus velit vitae ante. In dictum, metus sed lacinia sagittis, leo diam elementum tortor, rutrum elementum justo tellus eget risus. Curabitur faucibus mauris eget nisi. Nam mattis nunc eget turpis. In porta. Aliquam risus ante, sodales quis, consequat vitae, fermentum ut, nisi. Etiam congue ipsum id ante aliquet dictum.},
    
    :diff => %{<del>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Fusce gravida. Ut orci orci, molestie et, scelerisque ut, faucibus pharetra, enim. Morbi vehicula consequat nunc. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Quisque ac orci. Proin adipiscing tempor erat. Phasellus gravida tincidunt sapien. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. In venenatis libero sit amet quam. Nam sapien diam, tempor placerat, feugiat quis, congue in, elit. Vivamus nec enim eget elit posuere tincidunt. Quisque scelerisque lobortis risus. Quisque cursus dolor sit amet arcu.
</del><ins>Landscape architecture involves the investigation and designed response to the landscape. The scope of the profession includes architectural design, site planning, environmental restoration, town or urban planning, urban design, parks and recreation planning. A practitioner in the field of landscape architecture is called a landscape architect.
</ins>
Suspendisse auctor. Quisque sodales dapibus pede. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Cras blandit tellus id libero. Morbi sed purus sed sapien ornare facilisis. Vestibulum rutrum egestas mauris. Vestibulum luctus velit vitae ante. In dictum, metus sed lacinia sagittis, leo diam elementum tortor, rutrum elementum justo tellus eget risus. Curabitur faucibus mauris eget nisi. Nam mattis nunc eget turpis. In porta. Aliquam risus ante, sodales quis, consequat vitae, fermentum ut, nisi. Etiam congue ipsum id ante aliquet dictum.}
  }
end

def diff_html(from, to)
  RevisionSan::Diff.new(DiffTestEntity.new(from), DiffTestEntity.new(to)).text
end

describe "RevisionSan::Diff" do
  it "should return correctly formatted html" do
    [
      [long_text[:before], long_text[:after], long_text[:diff]],
      [nil, "First words.", "<ins>First words.</ins>"],
      ["First words.", nil, "<del>First words.</del>"],
      ["No changes.", "No changes.", "No changes."],
      ["Bla", "Foo", "<del>Bla</del><ins>Foo</ins>"],
      ["Bar!", "Baz!", "<del>Bar</del><ins>Baz</ins>!"],
      ["Begin\n\nEnd", "Begin\n\nMiddle\n\nEnd", "Begin\n\n<ins>Middle\n\n</ins>End"],
      ["Multiple added.", "Multiple words are added.", "Multiple <ins>words are </ins>added."],
      ["Multiple words are removed.", "Multiple removed.", "Multiple <del>words are </del>removed."],
      ["a\nb\nc\nd\n", "a\nc\nb\nd\n", "a\n<del>b</del><ins>c</ins>\nc\n<ins>b\n</ins>d\n"]
    ].each do |from, to, html|
      diff_html(from, to).should == html
    end
  end
end

class Artist
  def real_method
    obj = Object.new
    def obj.to_s
      'Real method'
    end
    obj
  end
end

describe "RevisionSan, looking at diff methods" do
  before do
    RevisionSanTest::Initializer.setup_database
    
    @artist_rev_2 = Artist.create(:name => 'van Gogh', :bio => 'He painted a lot.')
    @artist_rev_2.update_attributes(:name => 'Vincent van Gogh', :bio => 'He occasionally drew a lot.')
    @artist_rev_1 = @artist_rev_2.revisions.first
    
    @diff = @artist_rev_1.compare_against_revision(2)
  end
  
  after do
    RevisionSanTest::Initializer.teardown_database
  end
  
  it "should take an older revision number to compare against" do
    @artist_rev_2.compare_against_revision(1).should.be.instance_of RevisionSan::Diff
  end
  
  it "should have instantiated a RevisionSan::Diff object with the correct revisions" do
    @diff.from.should == @artist_rev_1
    @diff.to.should == @artist_rev_2
  end
  
  it "should lazy define accessors for requested columns" do
    @diff.name
    @diff.bio
    
    @diff.should.respond_to :name
    @diff.should.respond_to :bio
  end
  
  it "should also work with real existing methods instead of a column" do
    @diff.real_method
    @diff.should.respond_to :real_method
  end
  
  it "should coerce the value to a string before trying to diff them" do
    @diff.real_method.should == 'Real method'
  end
  
  it "should yield the from and to strings, if a block is given, so the user can adjust the text before diffing" do
    @diff.real_method { |text| text.reverse }.should == 'dohtem laeR'
  end
  
  it "should only define the accessors on the singleton, not the class" do
    @diff.name
    RevisionSan::Diff.instance_methods.should.not.include 'name'
  end
  
  it "should still raise a NoMethodError for column names that don't exist" do
    lambda { @diff.foo }.should.raise NoMethodError
  end
  
  it "should return html with the diff for a requested column" do
    @diff.name.should == "<ins>Vincent </ins>van Gogh"
    @diff.bio.should  == "He <del>painted</del><ins>occasionally drew</ins> a lot."
  end
end