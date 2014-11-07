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
