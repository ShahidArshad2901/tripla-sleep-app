module Pagination
  extend ActiveSupport::Concern

  private

  def pagination_meta(collection)
    {
      current_page: collection.current_page,
      next_page: collection.next_page,
      prev_page: collection.prev_page,
      total_pages: collection.total_pages,
      total_count: collection.total_count
    }
  end

  def page_params
    {
      page: params[:page] || 1,
      per_page: [ (params[:per_page] || 20).to_i, 100 ].min # Max 100 per page
    }
  end
end
