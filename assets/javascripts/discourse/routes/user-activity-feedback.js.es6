import UserActivityStreamRoute from "discourse/routes/user-activity-stream";
import UserAction from "discourse/models/user-action";
import RatingsStream from '../models/ratings-stream';

export default UserActivityStreamRoute.extend({
    userActionType: UserAction.TYPES["posts"],
    model(){
        let user = this.modelFor("user");
        user.isCurrentUser = Discourse.User.current().id === user.id;
        return RatingsStream.create({ user: user });
    },
    afterModel(model, transition){
        let user = this.modelFor("user");
        model.isCurrentUser = Discourse.User.current().id === user.id;
        model.filterBy(this.get("userActionType"), this.get("noContentHelpKey"));
    },
    renderTemplate(){
        this.render('user-activity-feedback');
    }
});
