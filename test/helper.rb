$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '../lib')))

ENV['OPENX_ENV'] = 'test'

require 'rubygems'
require 'bundler'

Bundler.setup
Bundler.require :test

require 'test/unit'
require 'openx'

module OpenX
  class TestCase < ActiveSupport::TestCase
    TEST_SWF    = File.expand_path(File.join(File.dirname(__FILE__), 'assets', 'cat.swf'))
    TEST_JPG    = File.expand_path(File.join(File.dirname(__FILE__), 'assets', '300x250.jpg'))

    Base        = OpenX::Services::Base
    Banner      = OpenX::Services::Banner
    Zone        = OpenX::Services::Zone
    Publisher   = OpenX::Services::Publisher
    Campaign    = OpenX::Services::Campaign
    Agency      = OpenX::Services::Agency
    Advertiser  = OpenX::Services::Advertiser
    Session     = OpenX::Services::Session

    undef :default_test

    def setup
      raise 'Please create the credentials file' unless File.exists?(OpenX.config_file)
    end

    def agency
      @agency ||= Agency.create!({
        :name         => "Testing! - #{Time.now}",
        :contact_name => 'Contact Name!',
        :email        => 'foo@bar.com'
      })
    end

    def advertiser
      @advertiser ||= Advertiser.create!(
        {
          :name         => "adv-#{Time.now}",
          :contact_name => 'Contact Name!',
          :email        => 'foo@bar.com'
        }.merge(:agency => agency)
      )
    end

    def campaign
      @campaign ||= Campaign.create!(
        {
          :advertiser => advertiser,
          :name         => "Campaign-#{Time.now}",
          :impressions => 2000
        }
      )
    end

    def publisher
      @publisher ||= Publisher.create!(
        {
          :agency       => agency,
          :name         => "Publisher! - #{Time.now}",
          :contact_name => 'Aaron Patterson',
          :email        => 'aaron@tenderlovemaking.com',
          :username     => 'one',
          :password     => 'two',
        }
      )
    end

    def zone
      @zone ||= Zone.create!(
        {
          :publisher  => publisher,
          :name       => "Zone - #{Time.now}",
          :type       => Zone::BANNER,
          :width      => 300,
          :height     => 250,
        }
      )
    end

    def banner
      @banner ||= Banner.create!({
        :name         => "Banner-#{Time.now}",
        :storage_type => Banner::LOCAL_SQL,
        :campaign     => campaign,
        :url          => 'http://tenderlovemaking.com/',
        :file_name    => 'oogabooga',
        :image        => OpenX::Image.new(File.open(TEST_SWF, 'rb'))
      })
    end

    def destroy
      @banner.destroy if defined? @banner
      @zone.destroy if defined? @zone
      @publisher.destroy if defined? @publisher
      @campaign.destroy if defined? @campaign
      @advertiser.destroy if defined? @advertiser
      @agency.destroy if defined? @agency
    end

  end
end
