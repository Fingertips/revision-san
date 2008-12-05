module RevisionSanTest
  module Initializer
    VENDOR_RAILS = File.expand_path('../../../../rails', __FILE__)
    OTHER_RAILS = File.expand_path('../../../rails', __FILE__)
    PLUGIN_ROOT = File.expand_path('../../', __FILE__)
    
    def self.rails_directory
      if File.exist?(VENDOR_RAILS)
        VENDOR_RAILS
      elsif File.exist?(OTHER_RAILS)
        OTHER_RAILS
      end
    end
    
    def self.load_dependencies
      if rails_directory
        $:.unshift(File.join(rails_directory, 'activesupport', 'lib'))
        $:.unshift(File.join(rails_directory, 'activerecord', 'lib'))
      else
        require 'rubygems' rescue LoadError
      end
      
      require 'activesupport'
      require 'activerecord'
      
      require 'rubygems' rescue LoadError
      
      require 'test/spec'
      require File.join(PLUGIN_ROOT, 'lib', 'revision_san')
    end
    
    def self.configure_database
      ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")
      ActiveRecord::Migration.verbose = false
    end
    
    def self.setup_database
      ActiveRecord::Schema.define(:version => 1) do
        create_table :members do |t|
          t.timestamps
        end

        create_table :artists do |t|
          t.integer :revision, :default => 1
          t.integer :revision_parent_id, :default => nil

          t.integer :member_id
          t.string  :name
          t.text    :bio
          t.timestamps
        end

        create_table :category_assignments do |t|
          t.integer :artist_id
          t.integer :category_id
          t.timestamps
        end
      end
    end
    
    def self.teardown_database
      ActiveRecord::Base.connection.tables.each do |table|
        ActiveRecord::Base.connection.drop_table(table)
      end
    end
    
    def self.start
      load_dependencies
      configure_database
    end
  end
end

RevisionSanTest::Initializer.start

class Member < ActiveRecord::Base
  has_one :artist
end

class Artist < ActiveRecord::Base
  belongs_to :member
  has_many :category_assignments
  
  include RevisionSan
  
  validates_presence_of :name
end

class CategoryAssignment < ActiveRecord::Base
  belongs_to :artist
end