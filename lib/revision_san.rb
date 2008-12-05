require File.expand_path('../revision_san/diff', __FILE__)

module RevisionSan
  def self.included(klass)
    klass.class_eval do
      before_update :create_new_revision
      named_scope :current_revisions, { :conditions => { :revision_parent_id => nil } }
      klass.extend ClassMethods
    end
  end
  
  module ClassMethods
    def find_with_current_revisions(*args)
      current_revisions.find_without_current_revisions(*args)
    end
    
    def count_with_current_revisions(*args)
      current_revisions.count_without_current_revisions(*args)
    end
    
    def self.extended(klass)
      class << klass
        alias_method_chain :find, :current_revisions
        alias_method_chain :count, :current_revisions
      end
    end
  end
  
  def revisions
    self.class.find_without_current_revisions(:all, :conditions => { :revision_parent_id => id }, :order => 'id ASC') + [self]
  end
  
  def fetch_revision(revision)
    revision = revision.to_i
    return self if self.revision == revision
    sub_query = revision_parent_id.blank? ? "revision_parent_id = #{id}" : "(id = #{revision_parent_id} OR revision_parent_id = #{revision_parent_id})"
    self.class.find_without_current_revisions :first, :conditions => "#{sub_query} AND revision = #{revision}"
  end
  
  def create_new_revision
    if changed?
      record = self.class.new(:revision_parent_id => id)
      attributes.except('id', 'revision_parent_id').each do |key, value|
        record.write_attribute(key, changes.has_key?(key) ? changes[key].first : value)
      end
      record.save(false)
      self.revision += 1
    end
  end
end