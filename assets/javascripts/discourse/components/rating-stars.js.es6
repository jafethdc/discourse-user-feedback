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
            this.$().css('cursor', 'pointer');
        }
        this.$().css('display', 'inline-block');

        if(this.get('owner') !== undefined){
            this.get('owner').send('setStars', this);
        }
    },
    click(event){
        let rating = this.getTarget(event.pageX);
        this.set('rating', rating);
        if(this.get('action') !== undefined){
            this.get('action')(rating);
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

    getTarget(x){
        const starsNumber = this.get('starsNumber');
        return Math.ceil((starsNumber * (x - this.$().offset().left) / this.$().width()));
    }
});