import InputValidation from 'discourse/models/input-validation';
import { default as computed, on } from 'ember-addons/ember-computed-decorators';

export default Ember.Component.extend({
    starsNumber: 5,
    readOnly: true,
    rating: 0,
    didReceiveAttrs(){
        this._super(...arguments);
        const stars = [];
        for(let i=0; i<this.get('starsNumber'); i++){
            let star  = { full: i < this.get('rating') };
            stars.push(star);
        }
        this.set('stars', stars);
    },
    didInsertElement(){
        this._super(...arguments);
        if(this.get('readOnly') === false){
            this.$('.rating-stars').css('cursor', 'pointer');
        }

        this.$('.popup-tip').css('left', this.$('.rating-stars').offset().left + this.$('.rating-stars').width() + 20);
        // this.$().css('display', 'inline-block');

        if(this.get('owner') !== undefined){
            this.get('owner').send('setStars', this);
        }
    },
    click(event){
        let rating = this.getTarget(event.pageX);
        if(rating <= this.get('starsNumber')){
            this.set('rating', rating);
            if(this.get('action') !== undefined){
                this.get('action')(rating);
            }
        }
    },
    updateStars: function(){
        let rating = this.get('rating');
        let stars = this.$('.star-icon');
        stars.each(function(index, element){
            if(index < rating){
                $(element).addClass('full');
            }else{
                $(element).removeClass('full');
            }
        });
    }.observes('rating'),

    validateStars(){
        if(!this.get('rating')>0){
            this.set('starsValidation', InputValidation.create({ failed: true, reason: I18n.t('user_feedback.rating_missing'), lastShownAt: Date.now()}));
            return false;
        }else{
            this.set('starsValidation', undefined);
            return true;
        }
    },

    getTarget(x){
        const starsNumber = this.get('starsNumber');
        return Math.ceil((starsNumber * (x - this.$().offset().left) / this.$('.rating-stars').width()));
    }
});