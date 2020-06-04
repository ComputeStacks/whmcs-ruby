##
# Generate usage data for testing
#
# Be sure to update the labels and email to match the user your testing against.
#
# Note: This should be run from the console of our demo server
#
# After this completed, you can export it by running:
#
#         File.open('aggregated_usage.yml', 'w') { |f| f.write aggregated.to_yaml }
#
processed_records = []
aggregated = []
billing_users = []
# Aggregate usage by (subscription, product)
BillingUsage.unscoped.select("distinct on (subscription_product_id) id, subscription_product_id, processed").where(processed: false).each do |i|
  aggreg_total = BillingUsage.unscoped.select("SUM(total) as bill_total, SUM(qty) as bill_qty").find_by(subscription_product_id: i.subscription_product_id, processed: false)
  next if aggreg_total.nil? || aggreg_total.bill_total < 0.01 # 1 Cent is the smallest unit we will process.
  pstart = nil
  pend = nil
  ext_id = nil
  items = []
  BillingUsage.where(users: {bypass_billing: false}, subscription_product_id: i.subscription_product_id, processed: false).joins(:user).each do |usage|
    billing_users << usage.user if usage.user && !billing_users.include?(usage.user)
    pstart = usage.period_start if pstart.nil? || usage.period_start < pstart
    pend = usage.period_end if pend.nil? || usage.period_end > pend
    next if pstart.nil? || pend.nil?
    ext_id = usage.external_id if ext_id.nil? && !usage.external_id.nil?
    processed_records << usage
    items << {
        id: usage.id,
        rate: usage.rate.to_f,
        qty: usage.qty.to_f,
        total: usage.total.to_f,
        period_start: usage.period_start.utc,
        period_end: usage.period_end.utc
    }
  end
  next if pstart.nil? || pend.nil?
  sub_product = i.subscription_product
  sub = sub_product.subscription
  product = sub_product.product
  aggregated << {
      subscription_id: sub&.id,
      subscription_product_id: i.subscription_product_id,
      product: { id: product.id, name: product.name, external_id: product.external_id },
      billing_resource: {
          id: sub_product.billing_resource.id,
          external_id: sub_product.billing_resource.external_id,
          billing_plan_id: sub_product.billing_resource.billing_plan_id
      },
      container_service_id: sub.linked_obj.is_a?(Deployment::Container) ? sub.linked_obj.service&.id : nil,
      container_id: sub.linked_obj.is_a?(Deployment::Container) ? sub.linked_obj.id : nil,
      device_id: sub.linked_obj.is_a?(Device) ? sub.linked_obj.id : nil,
      user: {
        id: sub_product.user.id,
        external_id: sub_product.user.external_id,
        email: 'jane.doe3-10@demo.computestacks.net',
        labels: {
          'whmcs' => {
            'client_id' => 3,
            'service_id' => 8
          }
        }
      },
      external_id: ext_id,
      total: aggreg_total.bill_total.to_f,
      qty: aggreg_total.bill_qty.to_f,
      period_start: pstart.utc,
      period_end: pend.utc,
      usage_items: items
  }
end
