class Bcome::ConfigFactory

  attr_reader :tree 

  def initialize
    @tree = { :views => [] }
    @collections = []
  end

  def flattened
    return @tree[:views].first
  end

  def add_crumbs(crumbs, data)
    views = @tree
    number_crumbs = crumbs.size

    crumbs.each_with_index do |crumb, index|
      is_last_crumb = (number_crumbs == (index + 1)) ? true : false
      if this_view = hash_for_identifier_from_view(crumb, views)
        views = this_view
      else
        this_view = { :identifier => crumb }
        this_view.merge!(:views => []) unless is_last_crumb && data[:type].to_sym == :inventory 
        views[:views] << this_view
        views = hash_for_identifier_from_view(crumb, views)
      end

     this_view.merge!(data) if is_last_crumb
    end
  end

  def hash_for_identifier_from_view(identifier, views)
    raise ::Bcome::Exception::InventoriesCannotHaveSubViews.new "Inventory cannot have subviews - invalid network config" unless views.has_key?(:views)
    views[:views].select{|v| v[:identifier].to_s == identifier.to_s }.first
  end

end
