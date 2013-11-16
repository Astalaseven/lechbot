# encoding: utf-8

require 'open-uri'
require 'json'
class StatusBot
    include Cinch::Plugin

    match /(open|close)/, :method => :changeStatus
    def changeStatus msg, status
        if ! config[:status_change_url] || config[:status_change_url].empty?
            msg.reply "URL de changement de statut non configurée"
            return
        end
        begin
            response = open("#{config[:status_change_url]}?status=#{status}")
            if status == "open"
                msg.reply "Le hackerspace est ouvert. PONEYZ EVERYWHERE <3"
            else
                msg.reply "Le hackerspace est fermé. N'oubliez pas d'éteindre les lumières et le radiateur !"
            end
        rescue Exception => e
            suffix = "(As-tu attendu 5min depuis le dernier changement de statut ?)"
            msg.reply "Erreur d'accès à SpaceAPI: #{e} !!! #{suffix if PRODUCTION}"
        end
    end

    match /status/, :method => :status
    def status msg
        if ! config[:status_get_url] || config[:status_get_url].empty?
            msg.reply "URL de récupération de statut non configurée"
            return
        end
        if ! config[:pamela_url] || config[:pamela_url].empty?
            msg.reply "URL Pamela configurée"
            return
        end
        response = JSON.parse open(config[:status_get_url]).read
        since = (response.key? 'since') ? "depuis le #{Time.at(response['since']).strftime('%d/%m/%Y %H:%M')}" : ''
        if response['state'] == "closed"
            msg.reply "Le hackerspace est fermé #{since} /o\\"
        else
            pamela_data = JSON.parse open(config[:pamela_url]).read
            people = pamela_data['color'].length + pamela_data['grey'].length
            msg.reply "Le hackerspace est ouvert #{since}, et il y a en ce moment #{people} personnes \\o/"
        end
    end
end
