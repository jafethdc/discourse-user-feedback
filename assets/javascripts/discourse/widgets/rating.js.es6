import { createWidget } from 'discourse/widgets/widget';
import { h } from 'virtual-dom';
import template from '../widgets/templates/rating';

export default createWidget('rating', {
    tagName: 'div.rating',

    defaultState(attrs) {
        return {
            post: attrs,
        }
    },

    html(){
        return template.render(this);
    }
});


