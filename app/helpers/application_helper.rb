module ApplicationHelper
  def pwa_manifest_tags
    tag(:link, rel: 'manifest', href: '/manifest.json')
  end
end
