import { emojiUnescape } from 'discourse/lib/text';
import UserAction from 'discourse/models/user-action';
import { ajax } from 'discourse/lib/ajax'

export default Ember.Component.extend({
    raw: '',
    rating: 0,
    actions: {
        updateRating(rating){
            this.set('rating', rating);
        },
        save(){
            const self = this;
            this.set('raw', this.$('textarea').val());
            this.set('loading', true);
            this.set('disableSubmit', true);
            const stream = this.get('stream');
            const user = stream.get('user');

            ajax(`/user-feedback/users/${user.id}.json`, {
                type: 'POST',
                data: {
                    raw: self.get('raw'),
                    rating: self.get('rating')
                }
            }).then(function (data) {
                let action = data.rating;
                const copy = Em.A();
                copy.pushObject(action);
                stream.get('content').insertAt(0, UserAction.collapseStream(copy)[0]);
                stream.set('itemsLoaded', stream.get('itemsLoaded') + 1)
                stream.set('rating', 0);
                self.get('starsComponent').set('rating', 0);
                self.$('textarea').val('');
                self.set('disableSubmit', false);
            }).finally(function(){
                self.set('loading', false);
            });
        },
        setStars(component){
            this.set('starsComponent', component);
        }
    },
});