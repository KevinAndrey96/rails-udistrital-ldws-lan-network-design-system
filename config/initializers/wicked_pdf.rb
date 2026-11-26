WickedPdf.config ||= {}
WickedPdf.config.merge!(
  # wkhtmltopdf >= 0.12.6 blocks file:// assets unless explicitly allowed, and
  # the reports embed their diagrams and icons from the asset pipeline.
  extra: '--enable-local-file-access'
)
