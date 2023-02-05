{
  "rules": [
    {
      "action": {
        "type": "expire"
      },
      "description": "Rotate images when reach ${max_image_count} images stored for hot-fixed images",
      "rulePriority": 1,
      "selection": {
        "countNumber": ${max_image_count},
        "countType": "imageCountMoreThan",
        "tagPrefixList": [
          "${staging_tag_prefix}",
          "${prod_tag_prefix}",
          "${version_tag_prefix}"
        ],
        "tagStatus": "tagged"
      }
    },
    {
      "action": {
        "type": "expire"
      },
      "description": "Rotate images when reach ${max_image_count} images stored for production images",
      "rulePriority": 2,
      "selection": {
        "countNumber": ${max_image_count},
        "countType": "imageCountMoreThan",
        "tagPrefixList": [
          "${prod_tag_prefix}",
          "${version_tag_prefix}"
        ],
        "tagStatus": "tagged"
      }
    },
    {
      "action": {
        "type": "expire"
      },
      "description": "Rotate images when reach ${max_image_count} images stored for sole production tags",
      "rulePriority": 3,
      "selection": {
        "countNumber": ${max_image_count},
        "countType": "imageCountMoreThan",
        "tagPrefixList": [
          "${version_tag_prefix}"
        ],
        "tagStatus": "tagged"
      }
    },
    {
      "action": {
        "type": "expire"
      },
      "description": "Rotate images when reach ${max_image_count} images stored for solo release tags",
      "rulePriority": 4,
      "selection": {
        "countNumber": ${max_image_count},
        "countType": "imageCountMoreThan",
        "tagPrefixList": [
          "${prod_tag_prefix}"
        ],
        "tagStatus": "tagged"
      }
    },
    {
      "action": {
        "type": "expire"
      },
      "description": "Rotate images when reach ${max_image_count} images stored for candidate tags",
      "rulePriority": 5,
      "selection": {
        "countNumber": ${max_image_count},
        "countType": "imageCountMoreThan",
        "tagPrefixList": [
          "${staging_tag_prefix}"
        ],
        "tagStatus": "tagged"
      }
    },
    {
      "action": {
        "type": "expire"
      },
      "description": "Rotate images when reach ${max_image_count} images stored for job images",
      "rulePriority": 6,
      "selection": {
        "countNumber": ${max_image_count},
        "countType": "imageCountMoreThan",
        "tagPrefixList": [
          "${job_tag_prefix}"
        ],
        "tagStatus": "tagged"
      }
    },
    {
      "action": {
        "type": "expire"
      },
      "description": "Rotate image any other images",
      "rulePriority": 7,
      "selection": {
        "countNumber": ${max_image_count},
        "countType": "imageCountMoreThan",
        "tagStatus": "any"
      }
    }
  ]
}
