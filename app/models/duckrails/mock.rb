class Duckrails::Mock < ActiveRecord::Base
  SCRIPT_TYPE_EMBEDDED_RUBY = 'embedded_ruby'
  SCRIPT_TYPE_STATIC = 'static'

  has_many :headers, dependent: :destroy
  accepts_nested_attributes_for :headers, allow_destroy: true, reject_if: :all_blank

  validates :status, presence: true
  validates :request_method, presence: true
  validates :route_path, presence: true, route: true, uniqueness: { scope: :request_method }
  validates :name, presence: true, uniqueness: true
  validates :body_type, inclusion: { in: [SCRIPT_TYPE_STATIC,
                                          SCRIPT_TYPE_EMBEDDED_RUBY],
                                     allow_blank: true },
                        presence: { unless: 'body_content.blank?' }
  validates :body_content, presence: { unless: 'body_type.blank?' }
  validates :script_type, inclusion: { in: [SCRIPT_TYPE_STATIC,
                                            SCRIPT_TYPE_EMBEDDED_RUBY],
                                     allow_blank: true },
                          presence: { unless: 'script.blank?' }
  validates :script, presence: { unless: 'script_type.blank?' }

  after_save :register
  after_destroy :unregister

  def dynamic?
    body_type != SCRIPT_TYPE_STATIC
  end

  def register
    Duckrails::Router.register_mock self
  end

  def unregister
    Duckrails::Router.unregister_mock self
  end
end
