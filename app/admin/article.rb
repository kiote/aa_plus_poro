ActiveAdmin.register Article do
  decorate_with ArticlePresenter

  permit_params :title

  index do
    column :id
    column :title
    column :hello
    column :link_title
  end
end
