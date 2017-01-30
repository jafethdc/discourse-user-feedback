export default Discourse.Route.extend({
    model(){
        let user = this.modelFor("user");
        return user;
    }
});