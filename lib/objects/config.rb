class Bcome::Config

  attr_reader :tree 

  def initialize
    @tree = {}
    @collections = []
  end

  def add_crumbs(crumbs)
    crumb_tree = { :views => [] }
   
    views = crumb_tree
    crumbs.each do |crumb|
      
      if views[:views].any? && (hash_for_identifier_from_view(crumb, views[:views]))
      else
        views[:views] << {
          :identifier => crumb,
          :views => []
        }
        views = hash_for_identifier_from_view(crumb, views)
      end
    end
    @collections << crumb_tree
  end

  def deep_merge_tree!
    @collections.each{|c| 
      @tree = @tree.deep_merge(c)
      puts @tree.inspect
    }
  end

  def hash_for_identifier_from_view(identifier, views)
     views[:views].select{|v| v[:identifier].to_s == identifier.to_s }.first
  end

end
