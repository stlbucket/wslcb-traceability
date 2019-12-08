<template>
  <div>
    <project-list-component
      :projects="projects"
    ></project-list-component>
  </div>
</template>

<script>
import allProjects from '@/graphql/query/allProjects.graphql'
import ProjectListComponent from '@/components/Prj/ProjectList'

export default {
  name: "ProjectListView",
  components: {
    ProjectListComponent
  },
  apollo: {
    init: {
      query: allProjects
      ,fetchPolicy: 'network-only'
      ,update (data) {
        this.projects = data.allProjects.nodes
      }
    }
  }
}
</script>
