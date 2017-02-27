import Topic from 'discourse/models/topic'
import { ajax } from 'discourse/lib/ajax'

export default Discourse.Route.extend({
    model(){
        let user = this.modelFor("user");

        return ajax(`/user-feedback/users/${user.id}.json`,{
            type: 'GET'
        }).then((data)=>{
            console.log(data);
            let topic = Topic.create(data);
            console.log(topic);
            return topic.post_stream;
        });

    },
});