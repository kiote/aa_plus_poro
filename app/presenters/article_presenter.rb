class ArticlePresenter < ModelPresenter
  def title
    record + 'hello'
  end
end
