# The name of this view in Looker is "Users"
view: users {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: `thelook.users`
    ;;
  drill_fields: [id]
  # This primary key is the unique key for this table in the underlying database.
  # You need to define a primary key in a view in order to join to other views.

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  # Here's what a typical dimension looks like in LookML.
  # A dimension is a groupable field that can be used to filter query results.
  # This dimension will be called "Age" in Explore.

  dimension: age {
    type: number
    sql: ${TABLE}.age ;;
  }

  dimension: age_tier {
    type: tier
    tiers: [15,26,36,51,66]
    style: integer
    sql: ${age} ;;
  }


  # A measure is a field that uses a SQL aggregate function. Here are defined sum and average
  # measures for this dimension, but you can also add measures of many different aggregates.
  # Click on the type parameter to see all the options in the Quick Help panel on the right.

  measure: total_age {
    type: sum
    sql: ${age} ;;
  }

  measure: average_age {
    type: average
    sql: ${age} ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}.country ;;
  }

  # Dates and timestamps can be represented in Looker using a dimension group of type: time.
  # Looker converts dates and timestamps to the specified timeframes within the dimension group.

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

  # ADDING DIMENSION FOR KEY USE CASE 2 ##

  dimension: days_since_sign_up {
    description: "The number of days since a customer has signed up on the website"
    type: number
    sql: DATE_DIFF(current_date(), ${created_date}, DAY);;
  }

  dimension: months_since_sign_up {
    description: "The number of months since a customer has signed up on the website"
    type: number
    sql: DATE_DIFF(current_date(), ${created_date}, month);;
  }

  dimension: tiered_days_since_sign_up  {
    description: "Customers grouped/tiered by days since they signed up"
    type: tier
    tiers: [100, 201, 301, 401, 501, 601, 701, 801,901,1001,1101,1201,1301,1401,1501]
    style: integer
    sql: ${days_since_sign_up} ;;
  }

  dimension: tiered_months_since_sign_up  {
    description: "Customers grouped/tiered by months since signed up"
    type: tier
    tiers: [12, 25, 37, 49]
    style: integer
    sql: ${months_since_sign_up} ;;
  }

  measure: average_days_since_signup {
    description: "Average number of days between a customer initially registering on the website and now"
    type: average
    sql: ${days_since_sign_up} ;;
  }

  measure: average_months_since_signup {
    description: "Average number of months between a customer initially registering on the website and now"
    type: average
    sql: ${months_since_sign_up} ;;
  }

  # ENDING ADDED LOOKML ##

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}.first_name ;;
  }

  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}.last_name ;;
  }

  dimension: latitude {
    type: number
    sql: ${TABLE}.latitude ;;
  }

  dimension: longitude {
    type: number
    sql: ${TABLE}.longitude ;;
  }

  dimension: postal_code {
    type: string
    sql: ${TABLE}.postal_code ;;
  }

  dimension: state {
    type: string
    map_layer_name: us_states
    sql: ${TABLE}.state ;;
  }

  dimension: street_address {
    type: string
    sql: ${TABLE}.street_address ;;
  }

  dimension: traffic_source {
    type: string
    sql: ${TABLE}.traffic_source ;;
    drill_fields: [gender, age_tier]
  }

  measure: count {
    type: count
    drill_fields: [id, last_name, first_name, events.count, order_items.count]
  }
}
