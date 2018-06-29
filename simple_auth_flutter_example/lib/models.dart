class Pokedex {
    String id;
    String type;
    Actor actor;

    Pokedex({
        this.id,
        this.type,
        this.actor,
    });

    factory Pokedex.fromJson(Map<String, dynamic> json) => new Pokedex(
        id: json['id'],
        type: json['type'],
        actor: Actor.fromJson(json['actor']),
    );

    Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'actor': actor.toJson(),
    };
}

class Actor {
    int id;
    String login;
    String displayLogin;
    String gravatarID;
    String url;
    String avatarURL;

    Actor({
        this.id,
        this.login,
        this.displayLogin,
        this.gravatarID,
        this.url,
        this.avatarURL,
    });

    factory Actor.fromJson(Map<String, dynamic> json) => new Actor(
        id: json['id'],
        login: json['login'],
        displayLogin: json['display_login'],
        gravatarID: json['gravatar_id'],
        url: json['url'],
        avatarURL: json['avatar_url'],
    );

    Map<String, dynamic> toJson() => {
        'id': id,
        'login': login,
        'display_login': displayLogin,
        'gravatar_id': gravatarID,
        'url': url,
        'avatar_url': avatarURL,
    };
}

