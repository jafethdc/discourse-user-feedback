import { h } from 'virtual-dom'
import RawHtml from 'discourse/widgets/raw-html';
import { dateNode } from 'discourse/helpers/node';
import { avatarImg } from 'discourse/widgets/post';
import { emojiUnescape } from 'discourse/lib/text';

export default Ember.Object.create({
    render(widget){
        this.widget = widget;
        this.post = widget.state.post;
        return this.container();
    },

    container(){
        return h('div.item.ember-view', [this.header(), this.content()]);
    },

    header(){
        return h('div.clearfix.info', [this.avatarWrapper(), this.postDate(), this.title()]);
    },

    content(){
       return new RawHtml({ html: `<div class="post-cooked">${this.post.cooked}</div>` })
    },

    avatarWrapper() {
        return h('div.avatar-wrapper', { attributes: { 'data-user-card': this.post.username } }, this.avatar())
    },

    avatar() {
        if (this.post.user_id) {
            // Stub here
            return avatarImg('medium', {template: this.post.avatar_template, username: this.post.username})
        } else {
            return h('i.fa.fa-trash-o.deleted-user-avatar')
        }
    },

    postDate(){
        return h('div.time', dateNode(this.post.created_at))
    },

    title(){
        return h('span.title', this.post.username)
    }
});
