require 'sprockets'
require 'sprockets/engines'
require 'action_view/helpers/javascript_helper'

module AngularRailsTemplates
  class Template < Tilt::Template
    include ActionView::Helpers::JavaScriptHelper

    def self.default_mime_type
      'application/javascript'
    end

    def prepare ; end

    def evaluate(scope, locals, &block)
      template = case File.extname(file)
               when HAML_EXT then HamlTemplate.new(self)
               when SLIM_EXT then SlimTemplate.new(self)
               else
                 BaseTemplate.new(self)
               end

      render_script_template(logical_template_path(scope), template.render)
    end

    protected

    def logical_template_path(scope)
      path = scope.logical_path
      path.gsub!(Regexp.new("^#{configuration.ignore_prefix}"), "")
      "#{path}.html"
    end

    def module_name
      configuration.module_name.inspect
    end

    def configuration
      ::Rails.configuration.angular_templates
    end

    def render_script_template(path, data)
      %Q{
window.angularTemplates || (window.angularTemplates = angular.module(#{module_name}, []));

window.angularTemplates.run(function($templateCache) {
  $templateCache.put(#{path.inspect}, "#{escape_javascript(data)}");
});
      }
    end

  end
end
