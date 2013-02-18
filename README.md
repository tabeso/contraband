# Contraband

Contraband's goal is to provide a cleaner, maintainable solution for importing
and mixing together data from external sources into a single record in a Rails
application.

## Installation

Add this line to your application's Gemfile:

    gem 'contraband'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install contraband

## Basic Usage

### Defining an Importer

In a Rails application, importers live in `app/importers` and follow a naming
convention of `<Service>Importer::<Model>`. For example, if you had the
following model:

```ruby
class Article
  include Mongoid::Document
  include Contraband::Importable

  field :title,   type: String
  field :content, type: String
end
```

You would implement a class for importing articles from Wikipedia as:

```ruby
class WikipediaImporter::Article < Contraband::Importer
  attributes :title, :content
end
```

and save it to `app/importers/wikipedia_importer/article.rb`. This naming
convention is used to avoid potential problems with conflicting class names
(when the name of a gem you use also uses the same name for its service) and to
keep a clean structure for reusing logic (e.g. a `WikipediaImporter::Base`
class).

The `attributes` method allows you to define the attributes you wish to import
from that particular service.

### Using an Importer

Continuing off of the previous example, when you've fetched your external data:

```ruby
page = Wikipedia.find('Smuggler')
# => #<Wikipedia:Page>
```

you can then import it:

```ruby
Article.import(:wikipedia, page)
# => true
```

### Aliasing Attributes

If the resources you fetch from other services don't share the same keys as your
models, you can alias them. If your model were to name its field `text`
*instead* of `content`, an attribute can be aliased like so:

```ruby
class WikipediaImporter::Article < Contraband::Importer
  attribute :content, as: :text
end
```

### Manipulating Data

In many cases, you will want to manipulate data in some way before storing. When
defining attributes, instance methods are generated with the same name which are
used by Contraband. By default, `attribute :title` generates a method
similar to:

```ruby
def title
  resource.title
end
```

If you were a horrible person, you might override the generated method to
capitalize every letter:

```ruby
class WikipediaImporter::Article < Contraband::Importer
  attributes :title, :content

  def title
    resource.title.upcase
  end
end
```

## Advanced Usage

More on that later... For now, you can read the source code. Feel free to ask
us for help if you have any questions. :)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request