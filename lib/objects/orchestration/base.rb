module Bcome::Orchestration
  class Base

    def execute(keyed_namespace)
      # TODO - we need a better way of keying into contexts without calling bootup.do every times as we've already loaded everything in

      # currently we: context = ::Bcome::Bootup.orchestrate(breadcrumb) 
      # but this actually ends up back at Bcome::Node::Factory and it reloads... so how can we avoid a reload?

      # THE WAY AROUND THIS:

      # Bootup becomes a singleton
      # and so, the @estate is already loaded, and so, we just need to traverse... should be quite easy

      # Bcome::Bootup.do is only called from two locations:
      # /bin/bcome
      # bootup.rb#orchestrate

      # once we have this, then we can call a variant of traverse but give it crumbs  def traverse(starting_context, breadcrumbs = crumbs) 

    end


  end
end
