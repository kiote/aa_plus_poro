# inspired by https://github.com/activeadmin/activeadmin/blob/a180c76f17480715948bff2ead827f338d95a835/spec/support/templates/post_decorator.rb
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