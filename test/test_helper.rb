module RevisionSanTest
  module Initializer
    def self.load_dependencies
      require 'active_record'
      require 'sqlite3'

      require 'bacon'

      require 'revision_san'
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