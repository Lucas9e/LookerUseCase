view: brand_comparisons {
  derived_table: {
    sql: SELECT
          (DATE(inventory_items.created_at )) AS inventory_items_created_date,
          inventory_items.id AS id,
          inventory_items.product_brand  AS inventory_items_product_brand,
          inventory_items.product_category  AS inventory_items_product_category,
          inventory_items.product_department  AS inventory_items_product_department,
          SUM(inventory_items.cost)  AS inventory_items_cost,
          SUM(inventory_items.product_retail_price)  AS inventory_items_product_retail_price,
      FROM `thelook.order_items`
           AS order_items
      LEFT JOIN `thelook.inventory_items`
           AS inventory_items ON order_items.inventory_item_id = inventory_items.id
      GROUP BY
          1,
          2,
          3,
          4,
          5
      ORDER BY
          1 DESC
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: inventory_items_id {
    description: "The ID of the inventory item (product)."
    type: number
    primary_key: yes
    sql: ${TABLE}.id ;;
  }

  dimension: created {
    description: "The date the item was sold."
    type: date
    datatype: date
    sql: ${TABLE}.inventory_items_created_date ;;
  }

  dimension: product_brand{
    description: "The brand of the product."
    type: string
    sql: ${TABLE}.inventory_items_product_brand ;;
  }

  dimension: product_category {
    description: "What category the product falls under."
    type: string
    sql: ${TABLE}.inventory_items_product_category ;;
  }

  dimension: product_department {
    description: "What department the product falls under."
    type: string
    sql: ${TABLE}.inventory_items_product_department ;;
  }

  dimension: cost {
    description: "The internal cost for the product."
    type: number
    sql: ${TABLE}.inventory_items_cost ;;
    value_format_name: usd
  }

  dimension: retail_price {
    description: "The sale price the product is sold for."
    type: number
    sql: ${TABLE}.inventory_items_product_retail_price ;;
    value_format_name: usd
  }

  measure: total_revenue {
    description: "Total Revenue"
    type: sum
    drill_fields: [gross_margin]
    sql: ${retail_price} ;;
    value_format_name: usd
  }

  measure: gross_margin {
    description: "Amount Total difference between the total revenue from completed sales and the cost of the goods that were sold "
    type: sum
    sql: ${retail_price} - ${cost} ;;
    value_format_name: usd

  }

  set: detail {
    fields: [
      created,
      product_brand,
      product_category,
      product_department,
      cost,
      retail_price
    ]
  }
}
