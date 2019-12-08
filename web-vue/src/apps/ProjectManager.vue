<template>
  <div>
    <h1>Project Manager</h1>
    <hr>
    <project-list-view></project-list-view>
  </div>
</template>

<script>
  import ProjectListView from '@/views/Prj/ProjectListView'


  export default {
    name: 'ProjectManager',
    components: {
      ProjectListView
    }
  }
</script>
