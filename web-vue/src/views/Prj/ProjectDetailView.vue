<template>
  <div>
    <project-detail-component
      :project="project"
    ></project-detail-component>
  </div>
</template>

<script>
import projectById from '@/graphql/query/projectById.graphql'
import ProjectDetailComponent from '@/components/Prj/ProjectDetail'

export default {
  name: "ProjectDetailView",
  components: {
    ProjectDetailComponent
  },
  props: {
    id: { 
      type: String,
      required: true
    }
  },
  apollo: {
    init: {
      query: projectById,
      fetchPolicy: 'network-only',
      variables () {
        // console.log('id', this.id)
        return {
          id: this.id
        }
      },
      update (data) {
        this.project = data.projectById
      }
    }
  }
}
</script>