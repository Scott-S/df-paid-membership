require_dependency 'application_controller'
module ::Df::PaidMembership class BaseController < ::ApplicationController
	before_filter :paypal_init
	protected
	def currency
		SiteSetting.send '«Money»_Currency'
	end
	def invoiceId
		nil
	end
	def log(message, params={})
		if log?
			Airbrake.notify(:error_message => log_prefix + message, :parameters => params)
		end
	end
	def log?
		true
	end
	# 2015-08-30
	# Не кэшируем результат, потому что invoice может сначала не существовать,
	# а потом существовать.
	def log_prefix
		result = ''
		if current_user
			result += "[#{current_user.username}] "
		end
		if invoiceId
			result += "[#{invoiceId}] "
		end
		result
	end
	def paypal_express_request
		prefix = sandbox? ? 'Sandbox_' : ''
		Paypal::Express::Request.new(
			:username => SiteSetting.send("«PayPal»_#{prefix}API_Username"),
			:password => SiteSetting.send("«PayPal»_#{prefix}API_Password"),
			:signature => SiteSetting.send("«PayPal»_#{prefix}Signature")
		)
	end
	def paypal_init
		Paypal.sandbox= sandbox?
		log sandbox? ? 'SANDBOX MODE' : 'PRODUCTION MODE'
	end
	def plans
		return @plans if defined? @plans
		@plans = begin
			JSON.parse(SiteSetting.send '«Paid_Membership»_Plans')
		rescue JSON::ParserError => e
			[]
		end
	end
	def recurring?
		SiteSetting.send('«PayPal»_Recurring')
	end
	def sandbox?
		# defined? @sandbox ? @sandbox : @sandbox = 'sandbox' === SiteSetting.send('«PayPal»_Mode')
		'sandbox' === SiteSetting.send('«PayPal»_Mode')
	end
end end
