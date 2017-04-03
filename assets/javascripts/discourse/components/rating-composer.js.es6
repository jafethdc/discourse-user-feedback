import { emojiUnescape } from 'discourse/lib/text';
import UserAction from 'discourse/models/user-action';
import { ajax } from 'discourse/lib/ajax'
import InputValidation from 'discourse/models/input-validation';

export default Ember.Component.extend({
    rating: 0,
    actions: {
        updateRating(rating){
            this.set('rating', rating);
        },
        save(){
            if(!this.valid()){ return; }

            this.set('loading', true);
            this.set('disableSubmit', true);

            const self = this;
            const stream = this.get('stream');
            const user = stream.get('user');

            ajax(`/user-feedback/users/${user.id}.json`, {
                type: 'POST',
                data: {
                    raw: self.$('textarea').val(),
                    rating: self.get('rating')
                }
            }).then(function (data) {
                let action = data.rating;
                const copy = Em.A();
                copy.pushObject(action);
                stream.get('content').insertAt(0, UserAction.collapseStream(copy)[0]);
                stream.set('itemsLoaded', stream.get('itemsLoaded') + 1);

                self.get('starsComponent').set('rating', 0);
                self.$('textarea').val('');
            }).finally(function(){
                self.set('loading', false);
                self.set('disableSubmit', false);
            });
        },
        setStars(component){
            this.set('starsComponent', component);
        },
    },
    valid(){
        let starsValid = this.get('starsComponent').validateStars();
        let textareaValid = this.validateTextarea();
        return starsValid && textareaValid;
    },
    validateTextarea(){
        if((this.$('textarea').val() === '')){
            this.set('textareaValidation', InputValidation.create({ failed: true, reason: I18n.t('user_feedback.comment_missing'), lastShownAt: Date.now()}));
            return false;
        }else{
            this.set('textareaValidation', undefined);
            return true;
        }
    }

});