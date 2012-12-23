# Revision-San

A simple Rails plugin which creates revisions of your model and comes with an equally simple HTML differ.

## Install

    $ gem install revision-san

## Usage

Include the `RevisionSan` module into the model for which you'd like to keep revisions.

```ruby
class Artist < ActiveRecord::Base
  include RevisionSan
end
```

And create a migration to add the columns needed by Revision-San to your model:

```ruby
add_column :artists, :revision, :integer,           :default => 1
add_column :artists, :revision_parent_id, :integer, :default => nil

add_index  :artists, :revision_parent_id
```
