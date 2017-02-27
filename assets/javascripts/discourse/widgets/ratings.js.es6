import { createWidget } from 'discourse/widgets/widget';
import { h } from 'virtual-dom';

export default createWidget('ratings', {
    tagName: 'div',

    html(attrs){
        let posts = attrs.posts.map((post, index) => {
            return this.attach('rating', post)
        });
        return h('div', posts)
    }
});