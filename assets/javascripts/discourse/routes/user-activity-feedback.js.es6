import UserActivityStreamRoute from "discourse/routes/user-activity-stream";
import UserAction from "discourse/models/user-action";
import RatingsStream from '../models/ratings-stream';

export default UserActivityStreamRoute.extend({
    userActionType: UserAction.TYPES["posts"],
    model(){
        return RatingsStream.create({ user: this.modelFor("user") });
    },
    afterModel(model, transition){
        model.filterBy(this.get("userActionType"), this.get("noContentHelpKey"));
    },
    setupController(controller, model){
        this._super(controller, model);
        controller.set('user', this.modelFor("user"));
    },
    renderTemplate(){
        this.render('user-activity-feedback');
    }
});
