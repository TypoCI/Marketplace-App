class ApplicationController < ActionController::Base
  before_action :setup_default_meta_tags_from_i18n
  before_action :set_raven_context

  def setup_default_meta_tags_from_i18n
    set_meta_tags(
      site: 'Typo CI',
      title: t('.title', default: '', scope: %w[meta_tags]),
      description: t('.description', default: '', scope: %w[meta_tags]),
      charset: 'utf-8',
      canonical: canonical_url,
      separator: '|',
      reverse: true
    )
  end

  def canonical_url
    url_for
  rescue ActionController::UrlGenerationError
    nil
  end

  def set_raven_context
    Raven.extra_context(params: params.to_unsafe_h, url: request.url, subdomain: request.subdomain)
  end
end
