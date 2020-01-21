require 'mail'
module Fastlane
  module Actions
    module SharedValues
      MAIL_TO_CUSTOM_VALUE = :MAIL_TO_CUSTOM_VALUE
    end

    class MailToAction < Action
      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        # UI.message "Parameter API Token: #{params[:api_token]}"

        # sh "shellcommand ./path"

        # Actions.lane_context[SharedValues::MAIL_TO_CUSTOM_VALUE] = "my_val"
        # helo = params[:helo]
        # to_user = params[:to_user]
        helo = 'wuweixin'
        to_user = 'wuweixin@4399inc.com'
        subject = params[:subject]
        body = params[:body]

        user_from = 'wessontest1@126.com'

        from = "wessontest1<#{user_from}>"
        to = "#{helo}<#{to_user}>"

        smtp = { :address => 'smtp.126.com',
                :port => 25,
                :domain => '126.com',
                :user_name => user_from,
                :password => 'wesson33mail',
                :enable_starttls_auto => true,
                :openssl_verify_mode => 'none',
        }


        Mail.defaults { delivery_method :smtp, smtp }

        mail = Mail.new do
          from from
          to to
          cc from # 抄送
          subject subject
          body body
        end

        mail.deliver!


      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "A short description with <= 80 characters of what this action does"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "You can use this action to do cool things..."
      end

      def self.available_options
        # Define all options your action supports. 
        
        # Below a few examples
        [
          # FastlaneCore::ConfigItem.new(key: :api_token,
          #                              env_name: "FL_MAIL_TO_API_TOKEN", # The name of the environment variable
          #                              description: "API Token for MailToAction", # a short description of this parameter
          #                              verify_block: proc do |value|
          #                                 UI.user_error!("No API token for MailToAction given, pass using `api_token: 'token'`") unless (value and not value.empty?)
          #                                 # UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
          #                              end),
          # FastlaneCore::ConfigItem.new(key: :development,
          #                              env_name: "FL_MAIL_TO_DEVELOPMENT",
          #                              description: "Create a development certificate instead of a distribution one",
          #                              is_string: false, # true: verifies the input is a string, false: every kind of value
          #                              default_value: false) # the default value if the user didn't provide one
          FastlaneCore::ConfigItem.new(key: :subject,
                             env_name: "FL_MAIL_TO_SUBJECT", # The name of the environment variable
                             description: "Subject for MailToAction", # a short description of this parameter
                             verify_block: proc do |value|
                                UI.user_error!("No Helo for MailToAction given, pass using `subject: 'subject'`") unless (value and not value.empty?)
                                # UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
                             end),
          FastlaneCore::ConfigItem.new(key: :body,
                              env_name: "FL_MAIL_TO_BODY", # The name of the environment variable
                              description: "Body for MailToAction", # a short description of this parameter
                              verify_block: proc do |value|
                                  UI.user_error!("No To User for MailToAction given, pass using `body: 'body'`") unless (value and not value.empty?)
                                  # UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
                              end)
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['MAIL_TO_CUSTOM_VALUE', 'A description of what this value contains']
        ]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["Your GitHub/Twitter Name"]
      end

      def self.is_supported?(platform)
        # you can do things like
        # 
        #  true
        # 
        #  platform == :ios
        # 
        #  [:ios, :mac].include?(platform)
        # 

        platform == :ios
      end
    end
  end
end
