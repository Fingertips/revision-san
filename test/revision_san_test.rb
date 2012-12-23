require_relative 'test_helper'

describe "RevisionSan, looking at model methods" do
  before do
    RevisionSanTest::Initializer.setup_database
    
    @artist = Artist.create(:name => 'van Gogh', :bio => 'He painted a lot.')
    @artist.update_attributes(:name => 'Vincent van Gogh', :bio => 'He painted a lot of nice paintings.')
    @artist.update_attributes(:name => 'Vincent van Gogh JR', :bio => 'Was never born.')
  end
  
  after do
    RevisionSanTest::Initializer.teardown_database
  end
  
  it "should only return current revisions when using ::find" do
    Artist.find(:all).should == [@artist]
  end
  
  it "should return all revisions" do
    revs = @artist.revisions
    revs.length.should == 3
    revs[0].should == Artist.find_without_current_revisions(:first, :conditions => { :revision => 1 })
    revs[1].should == Artist.find_without_current_revisions(:first, :conditions => { :revision => 2 })
    revs[2].should == Artist.find_without_current_revisions(:first, :conditions => { :revision => 3 })
  end
  
  it "should return a specific revision" do
    @artist.fetch_revision(1).should == @artist.revisions[0]
    @artist.fetch_revision(2).should == @artist.revisions[1]
    @artist.fetch_revision(3).should == @artist
    
    @artist.fetch_revision('1').should == @artist.revisions[0]
    @artist.fetch_revision('2').should == @artist.revisions[1]
    @artist.fetch_revision('3').should == @artist
  end
  
  it "should also be able to return a specific revision from an older revision" do
    @artist.fetch_revision(1).fetch_revision(2).fetch_revision(3).should == @artist
  end
  
  it "should convert a requested revision to an integer before using in the conditions" do
    @artist.fetch_revision('some evil sql that will be coerced to 0').should.be.nil
  end
end

describe "RevisionSan, when updating a record" do
  before do
    RevisionSanTest::Initializer.setup_database
    
    @artist = Artist.create(:name => 'van Gogh', :bio => 'He painted a lot.')
    @artist.update_attributes(:name => 'Vincent van Gogh', :bio => 'He painted a lot of nice paintings.')
  end
  
  after do
    RevisionSanTest::Initializer.teardown_database
  end
  
  it "should insert a new revision of a record" do
    lambda {
      @artist.update_attributes(:name => 'Vincent van Gogh JR', :bio => 'Was never born.')
    }.should.change { Artist.count_without_current_revisions }
  end
  
  it "should add the original attributes to the new revision record" do
    @artist.revisions.first.name.should == 'van Gogh'
    @artist.revisions.first.bio.should == 'He painted a lot.'
  end
  
  it "should not take over the created_at value" do
    created_at_before = @artist.created_at
    sleep 1
    @artist.update_attribute(:name, 'Gogh')
    
    @artist.revisions.first.created_at.should.not.be.same_as created_at_before
  end
  
  it "should not create a new revision record if no attributes were changed" do
    lambda {
      @artist.update_attributes({})
    }.should.not.change { Artist.count }
  end
  
  it "should not create a new revision if validation fails on the original record" do
    lambda {
      lambda {
        @artist.update_attributes({ :name => '', :bio => 'Lost his name...' })
      }.should.not.change { Artist.count }
    }.should.not.change { @artist.revision }
  end
end

describe "RevisionSan, class methods" do
  before do
    RevisionSanTest::Initializer.setup_database
    
    @gogh = Artist.create(:name => 'van Gogh, 1', :bio => 'He painted a lot.')
    9.times { |i| @gogh.update_attribute(:name, "van Gogh, #{i+2}") }
    
    @picasso = Artist.create(:name => 'Picasso, 1', :bio => 'He drank a lot.')
    9.times { |i| @picasso.update_attribute(:name, "Picasso, #{i+2}") }
  end
  
  after do
    RevisionSanTest::Initializer.teardown_database
  end
  
  it "should add a named_scope that only returns the latest revisions" do
    revisions = Artist.current_revisions
    revisions.map(&:id).should == [@gogh.id, @picasso.id]
    revisions.map(&:name).should == ["van Gogh, 10", "Picasso, 10"]
    revisions.map(&:revision).should == [10, 10]
  end
end