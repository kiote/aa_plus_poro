## README

This is sample project. Aim: to understand, how to decorate active admin resorces with POROs (Plain Old Ruby Objects).
I know, that AA could be easely decorated with Draper, 
but with [this](http://thepugautomatic.com/2014/03/draper/) article in mind I want to implement POROs-version.

As the result there is should be "decorated" title visible in the admin interface. 

You could also follow the discussion here: https://github.com/activeadmin/activeadmin/issues/3600

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

  index do
    column :id
    column :title
    column :hello       #delegated
    column :link_title  #delegated
  end
end

```

#### ArcticlePresenter
https://github.com/kiote/aa_plus_poro/blob/master/app/presenters/article_presenter.rb

```ruby
require 'delegated'

class ArticlePresenter < DelegateClass(Article)
  include Delegated

  def self.model_name
    ActiveModel::Name.new Article
  end

  def hello
    "Hello, #{title}"
  end

  def link_title
    helpers.link_to(id, url_helpers.admin_article_path(self))
  end
end
```

#### Delegated module

https://github.com/kiote/aa_plus_poro/blob/master/app/presenters/delegated.rb

```ruby
module Delegated
  extend ActiveSupport::Concern

  def helpers
    ActionController::Base.helpers
  end

  included do
    delegate :url_helpers, to: "Rails.application.routes"
  end

  module ClassMethods
    def decorate(*args)
      collection_or_object = args[0]
      if collection_or_object.respond_to?(:to_ary)
        class_name = collection_or_object.class.to_s.demodulize.gsub('ActiveRecord_Relation_', '')
        DecoratedEnumerableProxy.new(collection_or_object, class_name)
      else
        new(collection_or_object)
      end
    end

    def helpers
      ActionController::Base.helpers
    end
  end

  class DecoratedEnumerableProxy < DelegateClass(ActiveRecord::Relation)
    include Enumerable

    delegate :as_json, :collect, :map, :each, :[], :all?, :include?, :first, :last, :shift, :to => :decorated_collection

    def initialize(collection, class_name)
      super(collection)
      @class_name = class_name
    end

    def klass
      "#{@class_name}Presenter".constantize
    end

    def wrapped_collection
      __getobj__
    end

    def decorated_collection
      @decorated_collection ||= wrapped_collection.collect { |member| klass.decorate(member) }
    end
    alias_method :to_ary, :decorated_collection

    def each(&blk)
      to_ary.each(&blk)
    end
  end
end
```
