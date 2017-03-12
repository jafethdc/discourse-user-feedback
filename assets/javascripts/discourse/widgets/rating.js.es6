import { createWidget } from 'discourse/widgets/widget';
import { h } from 'virtual-dom';

export default createWidget('rating', {
    tagName: 'div.rating',

    html(attrs){
        console.log('rating!: ');
        console.log(attrs);
        let rating = attrs;
        let stars = [];
        for(let i=0;i<5;i++){
            let isFull = i < rating ? '.full' : '';
            stars.push(h('span.star-icon'+isFull,'☆'));
        }
        return stars;
    }
});


