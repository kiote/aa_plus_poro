ActiveAdmin.register Article do
  decorate_with ArticlePresenter

  permit_params :title
end
