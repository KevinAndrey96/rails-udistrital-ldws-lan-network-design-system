# == Schema Information
#
# Table name: requests
#
#  id               :integer          not null, primary key
#  title            :string
#  company_id       :integer
#  description      :string
#  objective        :string
#  observation      :string
#  web              :boolean
#  bd               :boolean
#  aplications      :boolean
#  proxy            :boolean
#  voip             :boolean
#  video_conference :boolean
#  active_dir       :boolean
#  dhcp             :boolean
#  dns              :boolean
#  ftp              :boolean
#  email            :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  ctype            :string
#
# Indexes
#
#  index_requests_on_company_id  (company_id)
#

class Request < ActiveRecord::Base
  # Services that each require a dedicated server in the design.
  SERVER_SERVICES = %i(web bd aplications proxy voip video_conference active_dir dhcp dns ftp email).freeze

  belongs_to :company
  has_one :logical
  has_many :physical
  has_many :buildings

  def required_server_count
    SERVER_SERVICES.count { |service| public_send("#{service}?") }
  end
end
