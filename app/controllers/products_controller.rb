class ProductsController < ApplicationController
  include ProductsControllerHelper
  TOTAL_PRODUCTS_RETURNED = 5

  def index
  	@products = Product.all.shuffle.shift(20)
    @simple_session.update_displayed_ids(@products)
  end


  def load
    preferred_dept = @simple_session[:value][:preferred_dept]

    freq_hash = DisplayPrioritizer.frequentize(@simple_session.ary_of_likes, @simple_session.ary_of_displayed_ids)
    top_ten_prod_ids = DisplayPrioritizer.top_prod_ids(freq_hash, TOTAL_PRODUCTS_RETURNED)
    top_prods = DisplayPrioritizer.get_top_prods(top_ten_prod_ids)
    if (params[:fill_with_random])
      num_random_products = TOTAL_PRODUCTS_RETURNED - top_prods.length
      top_prods = get_top_prods(preferred_dept, top_prods, num_random_products)
    end

    @simple_session.update_displayed_ids(top_prods)
    render partial: "products/product_list", locals: { products: top_prods }
  end

  def like
    product_id = params[:id].to_i
    product = Product.find(product_id)
    missing = product.identify_missing_asins
    ProductPrioritySet.add_to_set(product_id, missing)
    @simple_session.update_liked_ids(product_id)
    render :json => (product_id).to_json
  # rescue => e
  #   render :status => :unprocessable_entity, :json => {message: e}.to_json
  end

end
