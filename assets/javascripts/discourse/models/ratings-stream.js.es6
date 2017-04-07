import UserStream from 'discourse/models/user-stream';
import { url } from 'discourse/lib/computed';
import { ajax } from 'discourse/lib/ajax';
import UserAction from 'discourse/models/user-action';
import { emojiUnescape } from 'discourse/lib/text';

export default UserStream.extend({
    baseUrl: url('user.id', 'itemsLoaded', '/user-feedback/u/%@.json?offset=%@'),
    findItems(){
        const self = this;

        let findUrl = this.get('baseUrl');
        if (this.get('noContentHelpKey')) {
            findUrl += "&no_results_help_key=" + this.get('noContentHelpKey');
        }

        // Don't load the same stream twice. We're probably at the end.
        const lastLoadedUrl = this.get('lastLoadedUrl');
        if (lastLoadedUrl === findUrl) { return Ember.RSVP.resolve(); }

        if (this.get('loading')) { return Ember.RSVP.resolve(); }
        this.set('loading', true);
        return ajax(findUrl, {cache: 'false'}).then( function(result) {
            if (result && result.no_results_help) {
                self.set('noContentHelp', result.no_results_help);
            }
            if (result && result.user_actions) {
                const copy = Em.A();
                result.user_actions.forEach(function(action) {
                    action.title = emojiUnescape(Handlebars.Utils.escapeExpression(action.title));
                    copy.pushObject(UserAction.create(action));
                });

                self.get('content').pushObjects(UserAction.collapseStream(copy));
                self.setProperties({
                    itemsLoaded: self.get('itemsLoaded') + result.user_actions.length
                });
            }
        }).finally(function() {
            self.set('loaded', true);
            self.set('loading', false);
            self.set('lastLoadedUrl', findUrl);
        });
    }
});