export default Ember.Controller.extend({
    currentUserWatching: function(){
        let user = this.get('user');
        let currentUser = Discourse.User.current();
        return currentUser !== null && currentUser.id === user.id;
    }.property('model'),
    guestUserWatching: function(){
        let currentUser = Discourse.User.current();
        return currentUser === null;
    }.property()
});