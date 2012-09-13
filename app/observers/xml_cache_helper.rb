module XmlCacheHelper
  # Include this module into the controller and use cache_xml_response to cache the XML response
  # appropriately for a cache sweeper that includes the XmlCacheHelper module.
  module ControllerHelper
    def cache_xml_response(record)
      render :layout => false
      cache_page(
        response.body,
        url_for(
          :controller => self.class.controller_name,
          :action     => self.action_name,
          :id         => record.id,
          :format     => :xml,
          :only_path  => true
        )
      )
    end
    private :cache_xml_response
  end

  def self.included(base)
    base.class_eval do
      extend ClassMethods

      delegate :debug, :to => 'Rails.logger'

      # NOTE: Getting sweepers to work without a controller is not simple!
      #
      # All the documentation suggests that you should be able to simply define the observer methods
      # and then call expire_page with the url_for details.  However, this only works if the sweeper
      # has been paired with a controller, so that the controller is inserted into the sweeper.
      #
      # This is the best way of doing this, hence we simply implement an observer here and then
      # include & delegate everything we need to interact with the cache.
      include ActionController::UrlWriter
      delegate :expire_page, :perform_caching, :to => 'ActionController::Base'
      alias_method(:perform_caching?, :perform_caching)
      private :expire_page, :perform_caching, :perform_caching?
      private :url_for
    end
  end

  # After saving do cleanup of the cache.
  def after_save(record)
    handle(record)
  end

  # Before destroying do clean up of the cache, as after will be too late!
  def before_destroy(record)
    handle(record)
  end

  def handle(record)
    return unless perform_caching?
    debug { "Sweeping #{caching_for_controller} cache from #{record.class.name}(#{record.id})" }
    ids_for(record).compact.uniq.map(&method(:clear_cache))
    debug { "Cache sweeping of #{caching_for_controller} complete for #{record.class.name}(#{record.id})" }
  end
  private :handle

  def clear_cache(id)
    expire_page(url_for(
      :controller => caching_for_controller, :action => 'show', :id => id, :format => :xml,
      :only_path => true, :skip_relative_url_root => true
    ))
  end
  private :clear_cache

  # Finds all of the batches that the specified record relates to
  def ids_for(record)
    joins = Array(joins_for(record)).uniq
    query = "SELECT DISTINCT #{caching_for_model}.id AS id FROM #{caching_for_model} #{joins.join(' ')} WHERE #{record.class.table_name}.id=#{record.id}"
    ActiveRecord::Base.connection.select_all(query).map { |result| result['id'] }
  end
  private :ids_for

  def metadata
    metadata = "#{caching_for_model.to_s.singularize}_metadata"
    "INNER JOIN #{metadata} ON #{metadata}.#{caching_for_model.to_s.singularize}_id=#{caching_for_model.to_s.pluralize}.id"
  end
  private :metadata

  def metadata_association(type)
    metadata = "#{caching_for_model.to_s.singularize}_metadata"
    [
      "INNER JOIN #{metadata} ON #{metadata}.#{caching_for_model.to_s.singularize}_id=#{caching_for_model.to_s.pluralize}.id",
      "INNER JOIN #{type.to_s.pluralize} ON #{metadata}.#{type.to_s.singularlize}_id=#{type.to_s.pluralize}.id"
    ]
  end
  private :metadata_association

  module ClassMethods
    def self.extended(base)
      base.class_eval do
        delegate :caching_for_controller, :caching_for_model, :to => 'self.class'
      end
    end

    def set_caching_for_controller(name)
      @caching_for_controller = name
    end

    def caching_for_controller
      @caching_for_controller
    end

    def set_caching_for_model(name)
      @caching_for_model = name
    end

    def caching_for_model
      @caching_for_model
    end
  end
end