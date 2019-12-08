<template>
  <div>
    <h1>Name: {{ project.name }}</h1>
    <hr>
    <v-textarea
      :value="JSON.stringify(project,0,2)"
      auto-grow
    ></v-textarea>
  </div>
</template>

<script>
export default {
  name: "ProjectDetail",
  components: {
  },
    props: {
    project: { 
      type: Object,
      required: true
    }
  }
}
</script>
