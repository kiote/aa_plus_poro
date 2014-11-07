ActiveAdmin.register Article do
  decorate_with ArticlePresenter

  permit_params :title

  index do
    column :id
    column :title
    column :hello
  end
end
