## README

This is sample project. Aim: to understand, how to decorate active admin resorces with POROs (Plain Old Ruby Objects).
I know, that AA could be easely decorated with Draper, 
but with [this](http://thepugautomatic.com/2014/03/draper/) article in mind I want to implement POROs-version.


### Environment

Ruby 2.0.0p481

Rails 4.0.11

Active Admin 1.0.0.pre

SQLite database

### Decorator

#### Article at the resouce

https://github.com/kiote/aa_plus_poro/blob/master/app/admin/article.rb

```ruby
ActiveAdmin.register Article do
  decorate_with ArticlePresenter
  permit_params :title
end
```

#### ArcticlePresenter
https://github.com/kiote/aa_plus_poro/blob/master/app/presenters/article_presenter.rb

```ruby
class ArticlePresenter < ModelPresenter
  def title
    record + 'hello'
  end
end
```

#### ModelPresenter

https://github.com/kiote/aa_plus_poro/blob/master/app/presenters/model_presenter.rb

```ruby
class ModelPresenter
  # @return the object being decorated.
  attr_reader :record

  class << self
    alias_method :decorate, :new
  end

  def options
    {}
  end

  def initialize(record, _ = {})
    @record = record
  end

  # Delegates missing instance methods to the source object.
  def method_missing(method, *args, &block)
    record.send(method, *args, &block)
  end

  def respond_to?(symbol)
    super || record.respond_to?(symbol)
  end

  # decorate only with ArticlePresenter here to be simple
  def decorated_collection
    @decorated_collection ||= record.map { |article| ArticlePresenter.new(article) }
  end
end
```
