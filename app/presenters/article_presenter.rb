# inspired by https://github.com/activeadmin/activeadmin/blob/a180c76f17480715948bff2ead827f338d95a835/spec/support/templates/post_decorator.rb
require 'delegated'

class ArticlePresenter < DelegateClass(Article)
  include ActiveAdminPoroDecorator

  def self.model_name
    ActiveModel::Name.new Article
  end

  def self.columns
    Article.columns
  end

  def hello
    "Hello, #{title}"
  end

  def link_title
    helpers.link_to(id, url_helpers.admin_article_path(self))
  end
end